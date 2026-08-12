#!/usr/bin/env ruby
# frozen_string_literal: true

# herdr agent picker
#
# Same idea as space-picker.rb, but one row per agent instead of per space,
# so you can jump straight to a claude pane by what it is working on.
# Bound to prefix+a from a [[keys.command]] block in herdr/config.toml.

require_relative 'lib/herdr_picker'

include HerdrPicker # rubocop:disable Style/MixinUsage

agents = herdr_json('agent', 'list')['agents'] || []
die('no agents running') if agents.empty?

labels = workspace_labels
# Agents carry their own cwd, so branches come per agent rather than per space.
branches = branches_for(agents.to_h { |a| [a['pane_id'], a['cwd']] })

# Titles already start with their own status glyph (◐, ✳ …), which would just
# repeat the status column, so drop a leading symbol.
def clean_title(agent)
  title = agent['terminal_title_stripped'].to_s.strip
  title = agent['title'].to_s.strip if title.empty?
  title.sub(/\A[^\p{Alnum}]+\s*/, '')
end

lines = agents.map do |agent|
  marker = agent['focused'] ? '*' : ' '
  name = agent['display_agent'] || agent['name'] || agent['agent']

  display = format(
    '%<marker>s %<name>-8s %<status>s  %<space>-16s %<branch>s %<title>s',
    marker: marker,
    name: name.to_s,
    status: agent_status_cell(agent['agent_status']),
    space: labels[agent['workspace_id']].to_s,
    branch: padded_color(branches[agent['pane_id']], 22, BRANCH_COLOR),
    title: color(clean_title(agent), DIM)
  )

  "#{display}\t#{agent['pane_id']}"
end

# Start on the agent after the focused one, so prefix+a + enter cycles agents.
focused_index = agents.index { |a| a['focused'] }
start_index = focused_index ? (focused_index + 1) % agents.length : 0

pane_id = pick(lines, prompt: 'agent> ', start_index: start_index)
exit 0 unless pane_id

herdr_json('agent', 'focus', pane_id)
