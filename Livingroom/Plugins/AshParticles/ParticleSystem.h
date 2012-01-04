#pragma once

#include "Tree.h"
#include "Particle.h"

class ParticleSystem {
protected:
	float timeStep;
	vector<Particle> particles;
	Tree* tree;

public:
	ParticleSystem();

	void setTimeStep(float timeStep);

	void add(Particle& p);
	vector<Particle*> getNeighbors(float x, float y, float radius) const;
	unsigned size() const;
	Particle& operator[](unsigned i);

	void setupForces();
	void addRepulsionForce(const Particle& particle, float radius, float scale);
	void addRepulsionForce(float x, float y, float radius, float scale);
	void addAttractionForce(const Particle& particle, float radius, float scale);
	void addAttractionForce(float x, float y, float radius, float scale);
	void addForce(const Particle& particle, float radius, float scale);
	void addForce(float x, float y, float radius, float scale);
	void update();

	void draw();
};
