guard 'rspec', :version => 2 do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/scope_filter/(.+)\.rb})     { |m| "spec/lib/scope_filter/#{m[1]}_spec.rb" }
  watch('lib/scope_filter.rb') { "spec" }
  watch('spec/spec_helper.rb') { "spec" }
end
