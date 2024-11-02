# app/services/slack_notifier.rb

require "slack-notifier"

class SlackNotifier
  def self.notify(message)
    notifier = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"] do
      defaults channel: "#all-アラートメール確認用",
               username: "Notifier"
    end
    notifier.ping(message)
  end
end
