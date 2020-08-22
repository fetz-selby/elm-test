const getSeats = async ({ service, year, regionId }) =>
  await service
    .service("constituency_seats")
    .find({ query: { year, regionId } });

export { getSeats };
