const addPoll = async ({ service, poll }) =>
  await service.service("polls").create(poll);

const updatePoll = async ({ service, poll }) =>
  await service.service("polls").update(poll.id, poll);

const getPolls = async ({ service, year, regionId }) =>
  await service.service("polls").find({ query: { year, regionId } });

export { addPoll, updatePoll, getPolls };
