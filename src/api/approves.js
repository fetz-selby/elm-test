const getApproves = async ({ service, year, regionId }) =>
  await service.service("approve_list").find({ query: { year, regionId } });

export { getApproves };
