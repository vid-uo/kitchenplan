# Copyright 2014 Disney Enterprises, Inc. All rights reserved
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#
#   * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.

require 'spec_helper'
require 'ohai'
require 'kitchenplan'

describe Kitchenplan do
	describe "#detect_platform" do
		let(:system_ohai) { Ohai::System.new() }
		it "uses system ohai if the passed ohai param is nil" do
			system_ohai.load_plugins
			system_ohai.run_plugins(safe=false, attribute_filter=['platform','os'])
			@sys = system_ohai
			kp = Kitchenplan.new(ohai=nil)
			kp.detect_platform(ohai=nil)
			expect(kp.platform.ohai.data['os']).to eq @sys.data['os']
		end
	end
	describe "#detect_platform" do
		platforms = {
			'mac_os_x' => ['10.8.2','10.7.4'],
			'redhat' => ['6.3','5.8'],
			'ubuntu' => ['12.04'],
			'windows' => ['2008R2']

		}
		platforms.each do |platform, versions|
			versions.each do |version|
				context "On #{platform} #{version}" do
					let(:faux) { Fauxhai.mock(platform:platform, version:version) }
					let(:kp) { Kitchenplan.new(ohai=faux.data) }
					#let(:config) { Kitchenplan::Config.new(ohai=Fauxhai.mock(platform:platform, version:version).data, parse_configs=false)}
					it 'should load the corresponding Kitchenplan platform class' do
						case platform
						when /redhat|amazon|centos|xenserver|oracle/
							my_platform = "rhel"
						when /debian|ubuntu/
							my_platform = "debian"
						else
							my_platform = platform
						end
						expect(kp.platform.name).to eq(my_platform)
					end
				end
			end
		end

		context 'On an unsupported platform' do
					let(:faux) { Fauxhai.mock(platform:'freebsd', version:'9.1') }
					let(:kp) { Kitchenplan.new(ohai=faux.data) }
		it 'should raise an exception on an unsupported platform' do
			# TODO: Replace FreeBSD with a locally-distributed and wholly fictitious fixture
			expect { kp }.to raise_error
		end
		end
	end
	describe "#detect_resolver" do
		pending
	end
end
