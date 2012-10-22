Sequel.extension :inflector

Sequel.migration do
  up do
    create_table(:session) do
      primary_key :id
      String :session_id, :unique => true, :null => false
      DateTime :last_modified, :null => false

      BlobField :session_data, :null => true
    end


    create_table(:auth_db) do
      primary_key :id
      String :username, :unique => true, :null => false
      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
      String :pwhash, :null => false
    end


    create_table(:webhook_endpoint) do
      primary_key :id
      String :url, :unique => true, :null => false
    end


    create_table(:user) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      String :username, :null => false, :unique => true
      String :name, :null => false
      String :source, :null => false

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    create_table(:repository) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      String :repo_code, :null => false, :unique => true
      String :description, :null => false

      Integer :hidden, :default => 0

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    create_table(:group) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :repo_id, :null => false

      String :group_code, :null => false
      TextField :description, :null => false

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    alter_table(:group) do
      add_foreign_key([:repo_id], :repository, :key => :id)
      add_index([:repo_id, :group_code], :unique => true)
    end


    create_table(:group_user) do
      primary_key :id

      Integer :user_id, :null => false
      Integer :group_id, :null => false
    end


    alter_table(:group_user) do
      add_foreign_key([:user_id], :user, :key => :id)
      add_foreign_key([:group_id], :group, :key => :id)

      add_index(:group_id)
      add_index(:user_id)
    end


    create_table(:permission) do
      primary_key :id

      String :permission_code, :unique => true
      TextField :description, :null => false
      String :level, :default => "repository"

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    create_table(:group_permission) do
      primary_key :id

      Integer :permission_id, :null => false
      Integer :group_id, :null => false
    end


    alter_table(:group_permission) do
      add_foreign_key([:permission_id], :permission, :key => :id)
      add_foreign_key([:group_id], :group, :key => :id)

      add_index(:permission_id)
      add_index(:group_id)

      add_index([:permission_id, :group_id], :unique => true)
    end


    create_table(:accession) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :repo_id, :null => false

      String :identifier, :null => false, :unique => true

      String :title, :null => true
      TextField :content_description, :null => true
      TextField :condition_description, :null => true

      DateTime :accession_date, :null => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:accession) do
      add_foreign_key([:repo_id], :repository, :key => :id)
    end

    create_table(:resource) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :repo_id, :null => false
      String :title, :null => false

      String :identifier, :null => false

      Blob :notes, :null => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:resource) do
      add_foreign_key([:repo_id], :repository, :key => :id)
      add_index([:repo_id, :identifier], :unique => true)
    end


    create_table(:archival_object) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :repo_id, :null => false
      Integer :resource_id, :null => true

      Integer :parent_id, :null => true

      String :ref_id, :null => false, :unique => false
      String :component_id, :null => true

      TextField :title, :null => true
      String :level, :null => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:archival_object) do
      add_foreign_key([:repo_id], :repository, :key => :id)
      add_foreign_key([:resource_id], :resource, :key => :id)
      add_foreign_key([:parent_id], :archival_object, :key => :id)
      add_index([:resource_id, :ref_id], :unique => true)
    end


    create_table(:instance) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :resource_id
      Integer :archival_object_id

      String :instance_type, :null => false

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:instance) do
      add_foreign_key([:resource_id], :resource, :key => :id)
      add_foreign_key([:archival_object_id], :archival_object, :key => :id)
    end


    create_table(:container) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :instance_id

      String :type_1, :null => false
      String :indicator_1, :null => false
      String :barcode_1

      String :type_2
      String :indicator_2

      String :type_3
      String :indicator_3

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:container) do
      add_foreign_key([:instance_id], :instance, :key => :id)
    end


    create_table(:vocabulary) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      String :name, :null => false, :unique => true
      String :ref_id, :null => false, :unique => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    self[:vocabulary].insert(:name => "global", :ref_id => "global",
                               :create_time => Time.now, :last_modified => Time.now)


    create_table(:subject) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :vocab_id, :null => false

      String :terms_sha1, :unique => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:subject) do
      add_foreign_key([:vocab_id], :vocabulary, :key => :id)
    end


    create_table(:term) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :vocab_id, :null => false

      String :term, :null => false
      String :term_type, :null => false

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:term) do
      add_foreign_key([:vocab_id], :vocabulary, :key => :id)
      add_index([:vocab_id, :term, :term_type], :unique => true)
    end


    create_join_table({:subject_id => :subject, :term_id => :term}, :name => "subject_term")
    create_join_table({:subject_id => :subject, :archival_object_id => :archival_object}, :name => "subject_archival_object")
    create_join_table({:subject_id => :subject, :resource_id => :resource}, :name => "subject_resource")
    create_join_table({:subject_id => :subject, :accession_id => :accession}, :name => "subject_accession")


    create_table(:agent_person) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    create_table(:agent_family) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    create_table(:agent_corporate_entity) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    create_table(:agent_software) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    class Sequel::Schema::CreateTableGenerator
      def apply_name_columns
        String :authority_id, :null => true
        String :dates, :null => true
        TextField :description_type, :null => true
        TextField :description_note, :null => true
        TextField :description_citation, :null => true
        TextField :qualifier, :null => true
        String :source, :null => true
        String :rules, :null => true
        TextField :sort_name, :null => false
      end
    end

    create_table(:name_person) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :agent_person_id, :null => false

      String :primary_name, :null => false
      String :direct_order, :null => false

      TextField :title, :null => true
      TextField :prefix, :null => true
      TextField :rest_of_name, :null => true
      TextField :suffix, :null => true
      TextField :fuller_form, :null => true
      String :number, :null => true

      apply_name_columns

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    alter_table(:name_person) do
      add_foreign_key([:agent_person_id], :agent_person, :key => :id)
    end


    create_table(:name_family) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :agent_family_id, :null => false

      TextField :family_name, :null => false

      TextField :prefix, :null => true

      apply_name_columns

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    alter_table(:name_family) do
      add_foreign_key([:agent_family_id], :agent_family, :key => :id)
    end


    create_table(:name_corporate_entity) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :agent_corporate_entity_id, :null => false

      TextField :primary_name, :null => false

      TextField :subordinate_name_1, :null => true
      TextField :subordinate_name_2, :null => true
      String :number, :null => true

      apply_name_columns

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    alter_table(:name_corporate_entity) do
      add_foreign_key([:agent_corporate_entity_id], :agent_corporate_entity, :key => :id)
    end


    create_table(:name_software) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :agent_software_id, :null => false

      TextField :software_name, :null => false

      TextField :version, :null => true
      TextField :manufacturer, :null => true

      apply_name_columns

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    alter_table(:name_software) do
      add_foreign_key([:agent_software_id], :agent_software, :key => :id)
    end


    create_table(:agent_contact) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :agent_person_id, :null => true
      Integer :agent_family_id, :null => true
      Integer :agent_corporate_entity_id, :null => true
      Integer :agent_software_id, :null => true

      TextField :name, :null => false
      TextField :salutation, :null => true
      TextField :address_1, :null => true
      TextField :address_2, :null => true
      TextField :address_3, :null => true
      TextField :city, :null => true
      TextField :region, :null => true
      TextField :country, :null => true
      TextField :post_code, :null => true
      TextField :telephone, :null => true
      TextField :telephone_ext, :null => true
      TextField :fax, :null => true
      TextField :email, :null => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:agent_contact) do
      add_foreign_key([:agent_person_id], :agent_person, :key => :id)
      add_foreign_key([:agent_family_id], :agent_family, :key => :id)
      add_foreign_key([:agent_corporate_entity_id], :agent_corporate_entity, :key => :id)
      add_foreign_key([:agent_software_id], :agent_software, :key => :id)
    end


    create_table(:extent) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :accession_id, :null => true
      Integer :archival_object_id, :null => true
      Integer :resource_id, :null => true

      String :portion, :null => false
      String :number, :null => false
      String :extent_type, :null => false

      String :container_summary, :null => true
      String :physical_details, :null => true
      String :dimensions, :null => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:extent) do
      add_foreign_key([:accession_id], :accession, :key => :id)
      add_foreign_key([:archival_object_id], :archival_object, :key => :id)
      add_foreign_key([:resource_id], :resource, :key => :id)
    end

    create_table(:date) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :accession_id, :null => true
      Integer :archival_object_id, :null => true
      Integer :resource_id, :null => true
      Integer :event_id, :null => true

      String :date_type, :null => false
      String :label, :null => false

      String :uncertain, :null => true
      String :expression, :null => true
      String :begin, :null => true
      String :begin_time, :null => true
      String :end, :null => true
      String :end_time, :null => true
      String :era, :null => true
      String :calendar, :null => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    create_table(:event) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :repo_id, :null => false

      String :event_type, :null => false
      String :outcome, :null => true
      String :outcome_note, :null => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:event) do
      add_foreign_key([:repo_id], :repository, :key => :id)
    end


    alter_table(:date) do
      add_foreign_key([:accession_id], :accession, :key => :id)
      add_foreign_key([:archival_object_id], :archival_object, :key => :id)
      add_foreign_key([:resource_id], :resource, :key => :id)
      add_foreign_key([:event_id], :event, :key => :id)
    end


    event_links = [:agent_person, :agent_corporate_entity,
                   :agent_family, :agent_software,
                   :archival_object, :resource, :accession]

    event_links.each do |linked_table|
      table = "event_#{linked_table}".intern

      create_table(table) do
        primary_key :id

        Integer :event_id, :null => false
        Integer "#{linked_table}_id".intern, :null => false
        String :role, :null => false
      end


      alter_table(table) do
        add_foreign_key([:event_id], :event, :key => :id)
        add_foreign_key(["#{linked_table}_id".intern], linked_table.intern, :key => :id)
      end
    end



    create_table(:rights_statement) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :accession_id, :null => true
      Integer :archival_object_id, :null => true
      Integer :resource_id, :null => true

      Integer :repo_id, :null => false

      String :identifier, :null => false
      String :rights_type, :null => false

      Integer :active

      String :materials, :null => true

      String :ip_status, :null => true
      DateTime :ip_expiration_date, :null => true

      String :license_identifier_terms, :null => true
      String :statute_citation, :null => true

      String :jurisdiction, :null => true
      String :type_note, :null => true

      String :permission, :null => true
      String :restrictions, :null => true
      DateTime :restriction_start_date, :null => true
      DateTime :restriction_end_date, :null => true

      String :granted_note, :null => true

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    alter_table(:rights_statement) do
      add_foreign_key([:accession_id], :accession, :key => :id)
      add_foreign_key([:archival_object_id], :archival_object, :key => :id)
      add_foreign_key([:resource_id], :resource, :key => :id)

      add_foreign_key([:repo_id], :repository, :key => :id)
      add_index([:repo_id, :identifier], :unique => true)
    end


    create_table(:external_document) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      String :title, :null => false
      String :location, :null => false

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end


    records_supporting_external_documents = [:accession, :archival_object,
                                             :resource, :subject,
                                             :agent_person,
                                             :agent_family,
                                             :agent_corporate_entity,
                                             :agent_software,
                                             :rights_statement]

    records_supporting_external_documents.each do |record|
      create_join_table({
                          "#{record}_id".intern => record,
                          :external_document_id => :external_document
                        },
                        :name => "#{record}_external_document",
                        :index_options => {:name => "ed_#{record}_idx"})
    end


    create_table(:locations) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :repo_id, :null => false

      String :building, :null => false

      String :floor
      String :room
      String :area
      String :barcode
      String :classification
      String :coordinate_1_label
      String :coordinate_1_indicator
      String :coordinate_2_label
      String :coordinate_2_indicator
      String :coordinate_3_label
      String :coordinate_3_indicator
      String :temporary

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:locations) do
      add_foreign_key([:repo_id], :repositories, :key => :id)
    end

    create_table(:container_locations) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false

      Integer :location_id
      Integer :container_id

      String :status
      String :start_date
      String :end_date
      String :note

      DateTime :create_time, :null => false
      DateTime :last_modified, :null => false
    end

    alter_table(:container_locations) do
      add_foreign_key([:location_id], :locations, :key => :id)
      add_foreign_key([:container_id], :containers, :key => :id)
    end

  end

  down do

    [:external_document, :rights_statement, :location, :container_location,
     :subject_term, :subject_archival_object, :subject_resource, :subject_accession, :subject, :term,
     :agent_contact, :name_person, :name_family, :agent_person, :agent_family,
     :name_corporate_entity, :name_software, :agent_corporate_entity, :agent_software,
     :session, :auth_db, :group_user, :group_permission, :permission, :user, :group, :accession,
     :date, :event, :archival_object, :vocabulary, :extent, :resource, :repository,
     :accession_external_document, :archival_object_external_document,
     :external_document_resource, :external_document_subject,
     :agent_people_external_document, :agent_family_external_document,
     :agent_corporate_entity_external_document,
     :agent_software_external_document].each do |table|
      puts "Dropping #{table}"
      drop_table?(table)
    end

  end
end
