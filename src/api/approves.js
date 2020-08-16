const getApproves = async ({ service, year, regionId }) =>
  await service.service("approve_list").find({ query: { year, regionId } });

const updateApprove = async ({ service, approve }) =>
  await service.service("approve_list").update(0, approve);

export { getApproves, updateApprove };
