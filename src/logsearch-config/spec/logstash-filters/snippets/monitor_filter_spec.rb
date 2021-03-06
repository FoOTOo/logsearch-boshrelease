# encoding: utf-8
require 'spec_helper'

describe "Rules for parsing haproxy messages" do

  before(:all) do
    load_filters <<-CONFIG
      filter {
    #{File.read("src/logstash-filters/snippets/monitor_filter.conf")}
      }
    CONFIG
  end

  context 'when parsing a log with syslog structured data' do
    when_parsing_log(
      "syslog_sd_params" => { "job" => "elasticsearch_master", "index" => "1" },
      "syslog_program" => "elasticsearch",
      "@message" => '[2016-06-27 16:01:23,777][INFO ][node                     ] [elasticsearch_master/0] started'
    ) do

      it "sets @source.job" do
        expect(parsed_result.get("@source")["job"]).to eq "elasticsearch_master"
      end

      it "sets @source.index" do
        expect(parsed_result.get("@source")["index"]).to eq 1
      end

      it "sets @source.program" do
        expect(parsed_result.get("@source")["program"]).to eq "elasticsearch"
      end
    end
  end

  context 'when [@source][deployment] is set' do
    when_parsing_log(
        "@source" => { "deployment" => "deployment123" }
    ) do

      it "drops event" do
        expect(parsed_result).to be_cancelled
      end

    end
  end
end
