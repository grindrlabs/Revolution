#!/usr/bin/env ruby
# frozen_string_literal: true

module Deploy

  def self.initialize(aws = nil)
    puts '[Inside Deploy.initialize]'
    puts 'Getting AWS credentials...'
    puts 'Successfully initialized!'
    puts 'aws: ', aws
    aws
  end

  def self.deploy_to_s3
    puts '[Inside Deploy.deploy_to_s3]'
    puts 'Sending to repository...'
    puts 'Successfully deployed!'
  end
end
