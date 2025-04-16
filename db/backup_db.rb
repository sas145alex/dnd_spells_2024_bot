#!/usr/bin/env ruby

require "net/http"
require "json"
require "open3"

class Runner
  class Error < StandardError; end

  FOLDER = "/home/sneaky/_backups".freeze
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

Runner.new.call


