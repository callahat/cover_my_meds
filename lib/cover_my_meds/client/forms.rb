module CoverMyMeds
  module Forms
    include HostAndPath

    CURRENT_VERSION = 1

    def form_search form, drug_id, state, version=CURRENT_VERSION
      search_with_args({q: form}, drug_id, state, version)
    end

    def form_search_by_plan plan_hash, drug_id, state, version=CURRENT_VERSION
      search_with_args(plan_hash, drug_id, state, version)
    end

    def get_form form_id, version = CURRENT_VERSION
      data = forms_request GET, params: { v: version }, path: form_id
      Hashie::Mash.new(data['form'])
    end

    private

    def search_with_args(query_args, drug_id, state, version)
      params = query_args.merge(
        drug_id: drug_id,
        state: state,
        v: version
      )
      data = begin
               forms_request GET, params: params
             rescue CoverMyMeds::Error::HTTPError => e
               RestClient.log = Logger.new(STDOUT)
               forms_request GET, params: params
             end
      data['forms'].map { |d| Hashie::Mash.new(d) }
    end
  end
end
