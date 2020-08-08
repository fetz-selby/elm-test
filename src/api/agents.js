const addAgent = async ({ service, agent }) =>
  await service.service("agents").create(agent);

const getAgents = async ({ service, year }) =>
  await service.service("agents").find({ query: { year } });

export { addAgent, getAgents };
