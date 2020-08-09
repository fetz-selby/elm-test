const addUser = async ({ service, user }) =>
  await service.service("users").create(user);

const getUsers = async ({ service }) => await service.service("users").find();

export { addUser, getUsers };
