test_name 'Ensure Facter 3 and Facter 4 outputs match' do
  require 'puppet/acceptance/common_utils'

  confine :except, :platform => /el-5-x86_64|aix/

  exclude_list = %w{mountpoints\..*}

  agents.each do |agent|

    step 'run puppet facts diff ' do
      on agent, puppet('facts diff') do
        @diff = stdout
        
      end
    end

    step 'build exclude list' do
      diff_hash = JSON.parse(@diff)
      diff_hash.each do |key, value|
        unless value['old_value'] != nil
          exclude_list.append(key)
        end
      end
    end

    step 'compare Facter 3 to Facter 4 outputs' do
      ignored_facts = exclude_list.join("|").tr('"', '')
      on(agent, puppet("facts diff --exclude '#{ignored_facts}'")) do 
        require 'pry-byebug'
        binding.pry
        diff = JSON.parse(stdout)
        unless diff.size.zero?
          fail_test("Facter 3 and Facter 4 outputs have the following differences:  #{stdout}")
        end
      end
    end
  end
end
