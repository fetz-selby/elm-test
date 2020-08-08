const addAgent = async ({ service, agent }) =>
  await service.service("agents").create(agent);

const getAgents = async ({ service, year, regionId }) =>
  await service.service("agents").find({ query: { year, regionId } });

export { addAgent, getAgents };
