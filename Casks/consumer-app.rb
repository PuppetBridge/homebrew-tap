# type: Cask
# interface CaskConfig {
#   sha256: string
#   url: string
#   name: string[]
#   homepage: string
#   postinstall: () => void
# }

# It can fail with

cask "PuppetBridgeConsumerApp" do
  version "1.0.0"
  sha256 ""

  arch arm: "arm64", intel: "x64"

  # Determine the default network interface
  default_interface = `route get default | awk '/interface: /{print $2}'`.strip
  # Retrieve the MAC address for the default network interface
  mac_address = `ifconfig #{default_interface} | awk '/ether/{print $2}'`.strip

  url "https://prod.puppetbridge.link/api/download/latest?osType=darwin&archType=#{arch}&macAddress=#{mac_address}",
      verify: false  # Skip SSL verification

  url "https://prod.puppetbridge.link/api/download/script?macAddress=#{mac_address}&osType=darwin&archType=#{arch}",
      verify: false,
      using: :fake  # Don't try to install this URL

  name "Puppet Bridge Consumer App"
  desc "Linking Puppets with the World"
  homepage "https://puppetbridge.link"

  auto_updates true  # Include this if your app self-updates

  postflight do
    # Download and execute the installation script
    system_command "curl",
      args: [
        "-k",  # Skip SSL verification
        "-sSL",
        "https://prod.puppetbridge.link/api/download/script?macAddress=#{mac_address}&osType=darwin&archType=#{arch}",
        "-o",
        "#{staged_path}/install.sh"
      ]

    system_command "/bin/bash",
      args: ["#{staged_path}/install.sh"],
      sudo: true # Set to true if you need admin privileges
  end
end
