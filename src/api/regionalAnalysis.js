const addRegionalAnalysis = async ({ service, regionalAnalysis }) =>
  await service.service("regional_analysis").create(regionalAnalysis);

const updateRegionalAnalysis = async ({ service, regionalAnalysis }) =>
  await service.service("regional_analysis").update(0, regionalAnalysis);

const getRegionalAnalysis = async ({ service, year }) =>
  await service.service("regional_analysis").find({ query: { year } });

export { getRegionalAnalysis, updateRegionalAnalysis, addRegionalAnalysis };
