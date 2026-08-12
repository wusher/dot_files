# frozen_string_literal: true

# Shared bits for the herdr fzf pickers (space-picker.rb, agent-picker.rb).
#
# herdr sets HERDR_BIN_PATH for commands it spawns, so we use that instead of
# assuming herdr is on PATH inside the popup shell.

require 'json'
require 'open3'

module HerdrPicker
  HERDR = ENV.fetch('HERDR_BIN_PATH', 'herdr')
  ACTIVE_WORKSPACE = ENV['HERDR_ACTIVE_WORKSPACE_ID']

  # herdr reports one of: idle, working, blocked, done, unknown.
  # Symbol plus word plus color, so the status reads three ways at a glance.
  # "unknown" means no agent, so it prints as blank.
  AGENT_STATUS = {
    'working' => ['●', 'working', 33], # yellow
    'blocked' => ['▲', 'blocked', 31], # red
    'done' => ['✔', 'done',    32], # green
    'idle' => ['○', 'idle',    36], # cyan
    'unknown' => [' ', '',        0]
  }.freeze

  BRANCH_COLOR = 35 # magenta
  DIM = 90

  module_function

  def color(text, code)
    code.zero? || text.to_s.empty? ? text.to_s : "\e[#{code}m#{text}\e[0m"
  end

  # Pad first, colour second. Colour codes count as characters to format's
  # width specifiers, so padding a coloured string misaligns the columns.
  def padded_color(text, width, code)
    color(format("%-#{width}s", text.to_s), code)
  end

  def agent_status_cell(status)
    symbol, word, code = AGENT_STATUS.fetch(status.to_s, AGENT_STATUS['unknown'])
    color(format('%<symbol>s %<word>-7s', symbol: symbol, word: word), code)
  end

  def die(message)
    warn message
    # Popup closes the instant the command exits, so hold it open long enough
    # to actually read the error.
    warn 'press enter to close'
    $stdin.gets
    exit 1
  end

  # Runs a herdr CLI command and returns the parsed "result" object.
  def herdr_json(*args)
    raw, status = Open3.capture2(HERDR, *args)
    die("herdr #{args.join(' ')} failed:\n#{raw}") unless status.success?

    JSON.parse(raw)['result'] || {}
  rescue JSON::ParserError => e
    die("herdr #{args.join(' ')} returned unreadable JSON:\n#{e.message}")
  end

  def git_branch(dir)
    return '' if dir.to_s.empty?

    # symbolic-ref is empty on a detached HEAD, so fall back to the short sha.
    branch, status = Open3.capture2e('git', '-C', dir, 'symbolic-ref', '--quiet', '--short', 'HEAD')
    return branch.strip if status.success?

    sha, status = Open3.capture2e('git', '-C', dir, 'rev-parse', '--short', 'HEAD')
    status.success? ? sha.strip : ''
  end

  # One git call per entry, run at the same time so the popup stays instant.
  # Takes {key => dir}, returns {key => branch}.
  def branches_for(dirs)
    dirs.map { |key, dir| Thread.new { [key, git_branch(dir)] } }.map(&:value).to_h
  end

  # Every workspace's cwd, taken from its first pane. Workspaces carry no path
  # of their own. Returns {workspace_id => cwd}.
  def workspace_cwds
    panes = herdr_json('pane', 'list')['panes'] || []
    panes.each_with_object({}) { |pane, acc| acc[pane['workspace_id']] ||= pane['cwd'] }
  end

  def workspace_labels
    workspaces = herdr_json('workspace', 'list')['workspaces'] || []
    workspaces.to_h { |ws| [ws['workspace_id'], ws['label'].to_s] }
  end

  # Each fzf line is "<display>\t<id>". --with-nth=1 hides the id column so the
  # picker stays readable. Returns the chosen id, or nil when nothing was picked.
  #
  # start_index puts the cursor somewhere other than the first row.
  def pick(lines, prompt:, start_index: 0)
    return nil if lines.empty?

    args = [
      'fzf',
      '--delimiter', "\t",
      '--with-nth', '1',
      '--ansi',
      '--height', '100%',
      '--layout', 'reverse',
      '--prompt', prompt,
      '--no-multi',
      '--sync',
      '--bind', "load:pos(#{start_index + 1})"
    ]

    selection, = Open3.capture2(*args, stdin_data: lines.join("\n"))
    return nil if selection.strip.empty? # esc / no match

    id = selection.split("\t").last.to_s.strip
    id.empty? ? nil : id
  end
end
