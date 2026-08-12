#!/usr/bin/env ruby
# frozen_string_literal: true

# herdr space picker
#
# Lists herdr workspaces ("spaces"), pipes them through fzf, and focuses the
# one you pick. Bound to prefix+s from a [[keys.command]] block in
# herdr/config.toml with type = "popup".

require_relative 'lib/herdr_picker'

include HerdrPicker # rubocop:disable Style/MixinUsage

workspaces = herdr_json('workspace', 'list')['workspaces'] || []
die('no workspaces') if workspaces.empty?

branches = branches_for(workspace_cwds)

lines = workspaces.map do |ws|
  marker = ws['workspace_id'] == ACTIVE_WORKSPACE ? '*' : ' '

  display = format(
    '%<marker>s %<number>2d  %<label>-24s %<status>s  %<branch>s',
    marker: marker,
    number: ws['number'].to_i,
    label: ws['label'].to_s,
    status: agent_status_cell(ws['agent_status']),
    branch: color(branches[ws['workspace_id']], BRANCH_COLOR)
  )

  "#{display}\t#{ws['workspace_id']}"
end

# Start the cursor on the space after the active one, so a bare prefix+s +
# enter behaves like "next space".
active_index = workspaces.index { |ws| ws['workspace_id'] == ACTIVE_WORKSPACE }
start_index = active_index ? (active_index + 1) % workspaces.length : 0

workspace_id = pick(lines, prompt: 'space> ', start_index: start_index)
exit 0 unless workspace_id

herdr_json('workspace', 'focus', workspace_id)
