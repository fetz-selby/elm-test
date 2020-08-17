const addUser = async ({ service, user }) =>
  await service.service("users").create(user);

const updateUser = async ({ service, user }) =>
  await service.service("users").update(user.id, user);

const getUsers = async ({ service }) => await service.service("users").find();

export { addUser, updateUser, getUsers };
