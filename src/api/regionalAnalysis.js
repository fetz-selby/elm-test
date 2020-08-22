const addRegionalAnalysis = async ({ service, regionalAnalysis }) =>
  await service.service("regional_analysis").create(regionalAnalysis);

const updateRegionalAnalysis = async ({ service, regionalAnalysis }) =>
  await service
    .service("regional_analysis")
    .update(regionalAnalysis.id, regionalAnalysis);

const getRegionalAnalysis = async ({ service, year, regionId }) =>
  await service
    .service("regional_analysis")
    .find({ query: { year, regionId } });

export { getRegionalAnalysis, updateRegionalAnalysis, addRegionalAnalysis };
