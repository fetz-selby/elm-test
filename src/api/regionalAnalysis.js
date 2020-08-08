const addRegionalAnalysis = async ({ service, regionalAnalysis }) =>
  await service.service("regional_analysis").create(regionalAnalysis);

const getRegionalAnalysis = async ({ service, year }) =>
  await service.service("regional_analysis").find({ query: { year } });

export { getRegionalAnalysis, addRegionalAnalysis };
