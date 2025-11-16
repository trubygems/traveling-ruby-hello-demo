PACKAGE_NAME = "hello"
VERSION = "1.0.0"
TRAVELING_RUBY_VERSION = "20251107-3.4.7"
TRAVELING_RUBY_PKG_DATE = TRAVELING_RUBY_VERSION.split("-").first
TRAVELING_RB_VERSION = TRAVELING_RUBY_VERSION.split("-").last
RUBY_COMPAT_VERSION = TRAVELING_RB_VERSION.split(".").first(2).join(".") + ".0"
RUBY_MAJOR_VERSION = TRAVELING_RB_VERSION.split(".").first.to_i
RUBY_MINOR_VERSION = TRAVELING_RB_VERSION.split(".")[1].to_i

# Platform/target definitions
PLATFORMS = [
  { os: :linux,   arch: :x86_64, musl: false },
  { os: :linux,   arch: :arm64,  musl: false },
  { os: :linux,   arch: :x86_64, musl: true  },
  { os: :linux,   arch: :arm64,  musl: true  },
  { os: :macos,   arch: :x86_64, musl: false },
  { os: :macos,   arch: :arm64,  musl: false },
  { os: :windows, arch: :x86_64, musl: false },
  { os: :windows, arch: :arm64,  musl: false },
]

def platform_name(p)
  if p[:os] == :linux && p[:musl]
    "linux-musl-#{p[:arch]}"
  else
    "#{p[:os]}-#{p[:arch]}"
  end
end

def package_task_name(p)
  "package:#{platform_name(p)}"
end

def tarball_name(p)
  "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{platform_name(p)}.tar.gz"
end

# Generate all package tasks and file rules
PLATFORMS.each do |plat|
  desc "Package #{PACKAGE_NAME} for #{platform_name(plat)}"
  task package_task_name(plat) => [ tarball_name(plat) ] do
    create_package(TRAVELING_RUBY_VERSION, platform_name(plat), plat[:os] == :windows ? :windows : :unix)
  end

  file tarball_name(plat) do
    download_runtime(TRAVELING_RUBY_VERSION, platform_name(plat))
  end
end

# Meta tasks for groups
task "package:windows" => PLATFORMS.select { |p| p[:os] == :windows }.map { |p| package_task_name(p) }
task "package:linux"   => PLATFORMS.select { |p| p[:os] == :linux && !p[:musl] }.map { |p| package_task_name(p) }
task "package:linux:musl" => PLATFORMS.select { |p| p[:os] == :linux && p[:musl] }.map { |p| package_task_name(p) }
task "package:linux:glibc" => PLATFORMS.select { |p| p[:os] == :linux && !p[:musl] }.map { |p| package_task_name(p) }
task "package:macos"   => PLATFORMS.select { |p| p[:os] == :macos }.map { |p| package_task_name(p) }

desc "Package #{PACKAGE_NAME} for all platforms"
task :package => PLATFORMS.map { |p| package_task_name(p) }

def create_package(version, target, os_type)
  package_dir = "pkg/#{PACKAGE_NAME}-#{VERSION}-#{target}"
  sh "rm -rf #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app"
  sh "cp hello.rb #{package_dir}/lib/app/"
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"
  if os_type == :windows
    sh "cp packaging/wrapper.bat #{package_dir}/hello.bat"
  else
    sh "cp packaging/wrapper.sh #{package_dir}/hello"
  end
  if !ENV['DIR_ONLY']
    sh "tar -czf #{package_dir}.tar.gz #{package_dir}"
    sh "rm -rf #{package_dir}"
  end
end

def download_runtime(version, target)
  sh "cd packaging && curl -L -O --fail " +
     "https://github.com/YOU54F/traveling-ruby/releases/download/rel-#{TRAVELING_RUBY_PKG_DATE}/traveling-ruby-#{version}-#{target}.tar.gz"
end
