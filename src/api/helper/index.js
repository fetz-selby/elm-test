const sort = (a, b) =>
  a.name.toLowerCase() === b.name.toLowerCase()
    ? 0
    : a.name.toLowerCase() < b.name.toLowerCase()
    ? -1
    : 1;

export const normalizeCar = (car) => ({
  ...car,
  id: car && car.id ? car.id.toString() : "0",
  name: car && car.name ? car.name : "Unknown",
  imgUrl: car && car.img_url ? car.img_url.toString() : "",
  price: car && car.price ? car.price : 0.0,
});

export const normalizeCars = (cars) =>
cars && cars.length
    ? cars
        .map((car) => normalizeCar(car))
    : [];
