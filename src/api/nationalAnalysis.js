const getNationalAnalysis = async ({ service, year }) =>
  await service.service("national_analysis").find({ query: { year } });

export { getNationalAnalysis };
