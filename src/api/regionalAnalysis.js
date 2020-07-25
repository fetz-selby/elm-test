const getRegionalAnalysis = async ({ service, year }) =>
  await service.service("regional_analysis").find({ query: { year } });

export { getRegionalAnalysis };
