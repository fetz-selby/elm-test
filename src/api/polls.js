const addPoll = async ({ service, poll }) =>
  await service.service("polls").create(poll);

const getPolls = async ({ service, year, regionId }) =>
  await service.service("polls").find({ query: { year, regionId } });

export { addPoll, getPolls };
