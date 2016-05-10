class RecordsController < ApplicationController
  before_filter :get_repository


  def resource
    resource = JSONModel(:resource).find(params[:id], :repo_id => params[:repo_id], "resolve[]" => ["subjects", "container_locations", "digital_object", "linked_agents", "related_accessions", "repository", "repository::agent_representation", "classifications"])
    raise RecordNotFound.new if (!resource || !resource.publish)

    hash = resource.to_hash_with_translated_enums([
                                                   'language_iso639_2',
                                                   'linked_agent_role',
                                                   'linked_agent_archival_record_relators'],
                                                  :publishing)

    json = ASUtils.to_json(hash, {:max_nesting => false})

    render :json => json
  end


  def archival_object
    archival_object = JSONModel(:archival_object).find(params[:id], :repo_id => params[:repo_id], "resolve[]" => ["subjects", "container_locations", "digital_object", "linked_agents", "repository", "repository::agent_representation"])
    raise RecordNotFound.new if (!archival_object || archival_object.has_unpublished_ancestor || !archival_object.publish)

    render :json => archival_object.to_json
  end


  def accession
    accession = JSONModel(:accession).find(params[:id], :repo_id => params[:repo_id], "resolve[]" => ["subjects", "linked_agents", "container_locations", "digital_object", "related_resources", "repository", "repository::agent_representation", "classifications"])

    raise RecordNotFound.new if (!accession || !accession.publish)


    render :json => accession.to_json
  end


  def digital_object
    digital_object = JSONModel(:digital_object).find(params[:id], :repo_id => params[:repo_id], "resolve[]" => ["subjects", "linked_instances", "linked_agents", "repository"])
    raise RecordNotFound.new if (!digital_object || !digital_object.publish)

    render :json => digital_object.to_json
  end


  def classification
    classification = JSONModel(:classification).find(params[:id], :repo_id => params[:repo_id], "resolve[]" => ["subjects", "linked_agents", "repository", "creator"])
    raise RecordNotFound.new if (!classification || !classification.publish)

    render :json => classification.to_json
  end


  def classification_term
    classification_term = JSONModel(:classification_term).find(params[:id], :repo_id => params[:repo_id], "resolve[]" => ["repository", "creator"])
    raise RecordNotFound.new if (!classification_term || !classification_term.publish)

    render :json => classification_term.to_json
  end


  def agent_person
    agent_person = JSONModel(:agent_person).find(params[:id], "resolve[]" => ["related_agents"])

    hash = agent_person.to_hash_with_translated_enums(["agent_relationship_parentchild_relator", "agent_relationship_associative_relator",  "agent_relationship_subordinatesuperior_relator", "agent_relationship_earlierlater_relator", "rights_statement_rights_type"])

    json = ASUtils.to_json(hash, {:max_nesting => false})

    render :json => json
  end

  def repository
    agent_representation = JSONModel(:agent_corporate_entity).find_by_uri(@repository.agent_representation['ref'])

    hash = @repository.to_hash

    hash['agent_representation']['_resolved'] = agent_representation.to_hash

    json = ASUtils.to_json(hash, {:max_nesting => false})

    render :json => json
  end

  def get_repository
    @repository = @repositories.select{|repo| JSONModel(:repository).id_for(repo.uri).to_s === params[:repo_id]}.first
  end
end
