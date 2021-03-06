require 'serverspec'
require 'serverspec/type/base'

module Serverspec::Type
  class WindowsDSC < Base

    def initialize
      @runner = Specinfra::Runner
    end

    def able_to_get_dsc_configuration?
      command_result = @runner.run_command('$ProgressPreference = "SilentlyContinue"; $state = ""; do { $state = (Get-DscLocalConfigurationManager).LCMState; write-host "LCM state is $state"; Start-Sleep -Seconds 2; } while ($state -ne "Idle"); try { Get-DSCConfiguration -ErrorAction Stop; write-output "Get-DSCConfiguration succeeded"; $true } catch { write-output "Get-DSCConfiguration failed"; write-output $_; $false }')
      command_result.stdout.gsub(/\n/, '').match /Get-DSCConfiguration succeeded/
    end

    def has_applied_dsc_configuration_successfully?
      command_result = @runner.run_command('$ProgressPreference = "SilentlyContinue"; $state = ""; do { $state = (Get-DscLocalConfigurationManager).LCMState; write-host "LCM state is $state"; Start-Sleep -Seconds 2; } while ($state -ne "Idle"); try { if (-not (Test-DSCConfiguration -ErrorAction Stop)) { write-output "Test-DSCConfiguration returned false"; exit 1 } write-output "Test-DSCConfiguration succeeded"; exit 0 } catch { write-output "Test-DSCConfiguration failed"; write-output $_; exit 2 }')
      command_result.stdout.gsub(/\n/, '').match /Test-DSCConfiguration succeeded/
    end

    def to_s
      "Windows DSC"
    end

  end

  def windows_dsc
    WindowsDSC.new
  end
end

include Serverspec::Type
