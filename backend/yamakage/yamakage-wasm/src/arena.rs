use std::ops::Range;

#[derive(Clone)]
pub struct AzimuthGroup {
    pub azimuth_deg: f64,
    pub range: Range<usize>,
}

pub struct SamplingArena {
    pub lats: Vec<f64>,
    pub lngs: Vec<f64>,
    pub distances: Vec<f64>,
    pub elevations: Vec<f64>,
    pub groups: Vec<AzimuthGroup>,
}

impl SamplingArena {
    pub fn new() -> Self {
        Self {
            lats: Vec::new(),
            lngs: Vec::new(),
            distances: Vec::new(),
            elevations: Vec::new(),
            groups: Vec::new(),
        }
    }

    pub fn clear(&mut self) {
        self.lats.clear();
        self.lngs.clear();
        self.distances.clear();
        self.elevations.clear();
        self.groups.clear();
    }

    pub fn resize_elevations(&mut self) {
        self.elevations.resize(self.lats.len(), 0.0);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_arena_lifecycle() {
        let mut arena = SamplingArena::new();
        assert!(arena.lats.is_empty());

        arena.lats.push(35.0);
        arena.groups.push(AzimuthGroup {
            azimuth_deg: 0.0,
            range: 0..1,
        });
        arena.resize_elevations();

        assert_eq!(arena.elevations.len(), 1);

        arena.clear();
        assert!(arena.lats.is_empty());
        assert!(arena.groups.is_empty());
    }
}
