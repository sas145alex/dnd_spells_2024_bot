#!/usr/bin/env ruby

require "net/http"
require "json"
require "open3"

class Runner
  class Error < StandardError; end

  PWD = ENV["PWD"]
  FOLDER = "#{PWD}/backups".freeze
  DB_USER = "dnd_handbook".freeze
  DB_NAME = "dnd_handbook_production".freeze
  REMOTE_FOLDER = "drive:dnd_handbook_backups".freeze
  KEEP_BACKUP_TIME = "14d".freeze
  WEBHOOK = "https://discord.com/api/webhooks/1361757286141399132/6QU2WdzdnBcaDsesK5voXus0G0AMFdkTZz1yBAvGNYWN-zJ3ZMJRgglwwh5ztSbEzQ6d".freeze
  ERROR_MSG_LIMIT = 300
  SUCCESS_COLOR = 5763719
  FAILURE_COLOR = 15548997

  def call
    cmd = "rm -rf #{FOLDER}"
    process(cmd)

    cmd = "mkdir -p #{FOLDER}"
    process(cmd)

    cmd = "docker exec -t dnd_handbook-db pg_dump -c --if-exists -U #{DB_USER} -d #{DB_NAME} > #{FOLDER}/dump_$(date +%Y-%m-%d).sql"
    process(cmd)

    cmd = "rclone copy #{FOLDER} #{REMOTE_FOLDER}"
    process(cmd)

    cmd = "rclone delete --min-age #{KEEP_BACKUP_TIME} #{REMOTE_FOLDER}/"
    process(cmd)

    cmd = "rm -rf #{FOLDER}"
    process(cmd)

    notify_success
  rescue => e
    notify_failure(e)
  end

  private

  def process(cmd)
    puts cmd
    _stdout, stderr, status = Open3.capture3(cmd)

    return if status.success?

    raise Error, "command: #{cmd}\n #{stderr}"
  end

  def notify_success
    embed = {
      title: "Backup generation - OK",
      timestamp: Time.now.iso8601,
      color: SUCCESS_COLOR
    }
    body = {embeds: [embed]}
    notify(body)
  end

  def notify_failure(error = nil)
    embed = {
      title: "Backup generation - FAIL",
      timestamp: Time.now.iso8601,
      color: FAILURE_COLOR
    }.tap do |hash|
      if error
        text = "#{error.class} - #{error.message}"
        if text.size > ERROR_MSG_LIMIT
          threshold = (ERROR_MSG_LIMIT / 2).floor
          text = text[0...threshold] + "\n\n...\n\n" + text[-threshold..-1]
        end
        hash[:description] = text
      end
    end
    body = {embeds: [embed]}
    notify(body)
  end

  def notify(body)
    uri = URI.parse(WEBHOOK)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path)
    req["Content-Type"] = "application/json"
    req.body = body.to_json
    https.request(req)
  end
end

body = {embeds: [{title: "Backup generation - FAIL", timestamp: "2025-04-16T07:45:58+00:00", color: 15548997, description: "Runner::Error - command: rclone copy /home/sneaky/backups\n Usage:\n  rclone copy source:path dest:path [flags]\n\nFlags:\n      --create-empty-src-dirs   Create empty source dirs on destination after copy\n  -h, --help                    help for copy\n\nFlags for anything which can copy a file (flag group Copy):\n      --check-first                                 Do all the checks before starting transfers\n  -c, --checksum                                    Check for changes with size & checksum (if available, or fallback to size only)\n      --compare-dest stringArray                    Include additional server-side paths during comparison\n      --copy-dest stringArray                       Implies --compare-dest but also copies files from paths into destination\n      --cutoff-mode HARD|SOFT|CAUTIOUS              Mode to stop transfers when reaching the max transfer limit HARD|SOFT|CAUTIOUS (default HARD)\n      --ignore-case-sync                            Ignore case when synchronizing\n      --ignore-checksum                             Skip post copy check of checksums\n      --ignore-existing                             Skip all files that exist on destination\n      --ignore-size                                 Ignore size when skipping use modtime or checksum\n  -I, --ignore-times                                Don't skip items that match size and time - transfer all unconditionally\n      --immutable                                   Do not modify files, fail if existing files have been modified\n      --inplace                                     Download directly to destination file instead of atomic download to temp/rename\n  -l, --links                                       Translate symlinks to/from regular files with a '.rclonelink' extension\n      --max-backlog int                             Maximum number of objects in sync or check backlog (default 10000)\n      --max-duration Duration                       Maximum duration rclone will transfer data for (default 0s)\n      --max-transfer SizeSuffix                     Maximum size of data to transfer (default off)\n  -M, --metadata                                    If set, preserve metadata when copying objects\n      --modify-window Duration                      Max time diff to be considered the same (default 1ns)\n      --multi-thread-chunk-size SizeSuffix          Chunk size for multi-thread downloads / uploads, if not set by filesystem (default 64Mi)\n      --multi-thread-cutoff SizeSuffix              Use multi-thread downloads for files above this size (default 256Mi)\n      --multi-thread-streams int                    Number of streams to use for multi-thread downloads (default 4)\n      --multi-thread-write-buffer-size SizeSuffix   In memory buffer size for writing when in multi-thread mode (default 128Ki)\n      --no-check-dest                               Don't check the destination, copy regardless\n      --no-traverse                                 Don't traverse destination file system on copy\n      --no-update-dir-modtime                       Don't update directory modification times\n      --no-update-modtime                           Don't update destination modtime if files identical\n      --order-by string                             Instructions on how to order the transfers, e.g. 'size,descending'\n      --partial-suffix string                       Add partial-suffix to temporary file name when --inplace is not used (default \".partial\")\n      --refresh-times                               Refresh the modtime of remote files\n      --server-side-across-configs                  Allow server-side operations (e.g. copy) to work across different configs\n      --size-only                                   Skip based on size only, not modtime or checksum\n      --streaming-upload-cutoff SizeSuffix          Cutoff for switching to chunked upload if file size is unknown, upload starts after reaching cutoff or when file ends (default 100Ki)\n  -u, --update                                      Skip files that are newer on the destination\n\nImportant flags useful for most commands (flag group Important):\n  -n, --dry-run         Do a trial run with no permanent changes\n  -i, --interactive     Enable interactive mode\n  -v, --verbose count   Print lots more stuff (repeat for more)\n\nFlags for filtering directory listings (flag group Filter):\n      --delete-excluded                     Delete files on dest excluded from sync\n      --exclude stringArray                 Exclude files matching pattern\n      --exclude-from stringArray            Read file exclude patterns from file (use - to read from stdin)\n      --exclude-if-present stringArray      Exclude directories if filename is present\n      --files-from stringArray              Read list of source-file names from file (use - to read from stdin)\n      --files-from-raw stringArray          Read list of source-file names from file without any processing of lines (use - to read from stdin)\n  -f, --filter stringArray                  Add a file filtering rule\n      --filter-from stringArray             Read file filtering patterns from a file (use - to read from stdin)\n      --ignore-case                         Ignore case in filters (case insensitive)\n      --include stringArray                 Include files matching pattern\n      --include-from stringArray            Read file include patterns from file (use - to read from stdin)\n      --max-age Duration                    Only transfer files younger than this in s or suffix ms|s|m|h|d|w|M|y (default off)\n      --max-depth int                       If set limits the recursion depth to this (default -1)\n      --max-size SizeSuffix                 Only transfer files smaller than this in KiB or suffix B|K|M|G|T|P (default off)\n      --metadata-exclude stringArray        Exclude metadatas matching pattern\n      --metadata-exclude-from stringArray   Read metadata exclude patterns from file (use - to read from stdin)\n      --metadata-filter stringArray         Add a metadata filtering rule\n      --metadata-filter-from stringArray    Read metadata filtering patterns from a file (use - to read from stdin)\n      --metadata-include stringArray        Include metadatas matching pattern\n      --metadata-include-from stringArray   Read metadata include patterns from file (use - to read from stdin)\n      --min-age Duration                    Only transfer files older than this in s or suffix ms|s|m|h|d|w|M|y (default off)\n      --min-size SizeSuffix                 Only transfer files bigger than this in KiB or suffix B|K|M|G|T|P (default off)\n\nFlags for listing directories (flag group Listing):\n      --default-time Time   Time to show if modtime is unknown for files and directories (default 2000-01-01T00:00:00Z)\n      --fast-list           Use recursive list if available; uses more memory but fewer transactions\n\nUse \"rclone [command] --help\" for more information about a command.\nUse \"rclone help flags\" for to see the global flags.\nUse \"rclone help backends\" for a list of supported services.\nCommand copy needs 2 arguments minimum: you provided 1 non flag arguments: [\"/home/sneaky/backups\"]\n"}]}
oo = Runner.new
rr = oo.send(:notify, body)

Runner.new.call


