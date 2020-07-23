export const flatenConstituenciesWithRegionIdIncluded = (
  parentConstituencies,
  constituencies
) =>
  constituencies.reduce((acc, curr) => {
    const foundParentConstituency = parentConstituencies.find(
      (parentConstituency) =>
        parentConstituency.id.toString() === curr.parent_id.toString()
    );

    acc.push({ ...curr, region_id: foundParentConstituency.region_id });
    return acc;
  }, []);

export const normalizeConstituency = (constituency) => ({
  ...constituency,
  is_declared: constituency.is_declared.toLowerCase() === "y",
  auto_compute: constituency.auto_compute.toLowerCase() === "t",
});

export const normalizeConstituencies = (constituencies) =>
  constituencies && constituencies.length
    ? constituencies.map((constituency) => normalizeConstituency(constituency))
    : [];

export const normalizeCandidate = (candidate) => ({
  ...candidate,
  votes: parseInt(candidate.votes),
  year: candidate.year.toString(),
  constituency: normalizeConstituency(candidate.constituency),
  bar_ratio: parseFloat(candidate.bar_ratio),
  percentage: parseFloat(candidate.percentage),
  angle: parseFloat(candidate.angle),
});

export const normalizeCandidates = (candidates) =>
  candidates && candidates.length
    ? candidates.map((candidate) => normalizeCandidate(candidate))
    : [];
