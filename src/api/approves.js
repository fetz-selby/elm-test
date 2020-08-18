const getApproves = async ({ service, year, regionId }) =>
  await service.service("approve_list").find({ query: { year, regionId } });

const updateApprove = async ({ service, approve }) =>
  await service.service("approve_list").update(approve.id, approve);

const removeApprove = async ({ service, id }) =>
  await service.service("approve_list").remove(id);

export { getApproves, updateApprove, removeApprove };
