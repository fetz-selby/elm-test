const getLogin = async ({ service, email, password }) =>
  await service.service("login").find({ query: { email, password } });

export { getLogin };
