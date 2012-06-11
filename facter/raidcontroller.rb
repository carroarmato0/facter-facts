Facter.add("raidcontroller") do
	confine :kernel => :linux

	setcode do
		controllers = Array.new

		if File.executable?("/usr/bin/lspci")
			output = %x{/usr/bin/lspci}
			output.each do |line|
				controllers.push("sas2ircu") if line =~ /SAS2008/
				controllers.push("megaraid") if line =~ /(MegaRAID SAS 1078|MegaSAS 9260|MegaRAID SAS 9240)/
			end
		end

		if File.readable?("/proc/mpt/ioc0/info")
			File.open("/proc/mpt/ioc0/info").each do |line|
				if line =~ /LSISAS1068E/ or line =~/LSISAS1064E/
					if File.executable?('/usr/sbin/mpt-status')
						output=%x{/usr/sbin/mpt-status}
							controllers.push("sas1068") if output =~ /ioc0/m
					end
				end
			end
		end

		if File.readable?("/proc/mdstat")
			mdstat = File.read("/proc/mdstat")
			controllers.push("linux_software_raid") if mdstat =~ /^md/mi
		end

		controllers.uniq.join(",")
	end
end
