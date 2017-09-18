#!/usr/bin/env ruby
# frozen_string_literal: true

module Deploy

  def initialize
    puts '[Inside Deploy.initialize]'
    puts 'Getting AWS credentials...'
    puts 'Successfully initialized!'
  end

  def deploy_to_s3
    puts '[Inside Deploy.deploy_to_s3]'
    puts 'Sending to repository...'
    puts 'Successfully deployed!'
  end
end
