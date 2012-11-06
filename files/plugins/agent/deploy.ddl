metadata :name        => 'Puppet Deploy, now with Mcollective!',
         :description => 'Run puppet_deploy.rb on all masters',
         :author      => 'Adrien Thebo',
         :license     => 'Do whatever the fuck you want',
         :url         => 'http://purple.com',
         :version     => '0.0.1',
         :timeout     => 300

action 'puppet', :description => 'Deploy Puppet manifests' do
  display :always

  input :parallel,
        :description => 'Whether to fork for each environment',
        :type        => :boolean,
        :default     => true

  input :librarian,
        :description => 'Whether to update librarian',
        :type        => :boolean,
        :default     => true

  output :status,
         :description => 'The status of puppet_deploy.rb',
         :display_as  => 'Status'
end
