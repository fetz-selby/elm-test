const addNationalAnalysis = async ({ service, nationalAnalysis }) =>
  await service.service("national_analysis").create(nationalAnalysis);

const updateNationalAnalysis = async ({ service, nationalAnalysis }) =>
  await service.service("national_analysis").update(0, nationalAnalysis);

const getNationalAnalysis = async ({ service, year }) =>
  await service.service("national_analysis").find({ query: { year } });

export { getNationalAnalysis, updateNationalAnalysis, addNationalAnalysis };
