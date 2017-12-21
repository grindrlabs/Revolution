# frozen_string_literal: true

module Build
  def self.build_package(pkg_path)
    build_cmd    = "fpm-cook package --no-deps #{pkg_path}/recipe.rb"
    pid          = Process.spawn(build_cmd)
    _pid, status = Process.wait2(pid)
    status.exitstatus
  end

  def self.install_build_deps(pkg_path)
    # TODO: needs to use sudo in Travis, which requires containers
    install_cmd  = "fpm-cook install-build-deps #{pkg_path}/recipe.rb"
    pid          = Process.spawn(install_cmd)
    _pid, status = Process.wait2(pid)
    status.exitstatus
  end

  def self.clean(pkg_path)
    pid          = Process.spawn("fpm-cook clean #{pkg_path}/recipe.rb")
    _pid, status = Process.wait2(pid)
    status.exitstatus
  end

  def self.remove_package(pkg_path)
    pid          = Process.spawn("cd #{pkg_path} && rm -rf cache pkg tmp-build tmp-dest")
    _pid, status = Process.wait2(pid)
    status.exitstatus
  end
end
