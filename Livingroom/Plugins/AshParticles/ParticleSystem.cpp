#include "ParticleSystem.h"

ParticleSystem::ParticleSystem() :
	timeStep(1),
	tree(NULL) {
}

void ParticleSystem::setTimeStep(float timeStep) {
	this->timeStep = timeStep;
}

void ParticleSystem::add(Particle& p) {
	particles.push_back(p);
}

unsigned ParticleSystem::size() const {
	return particles.size();
}

Particle& ParticleSystem::operator[](unsigned i) {
	return particles[i];
}

vector<Particle*> ParticleSystem::getNeighbors(float x, float y, float radius) const {
	return tree->getNeighbors(x, y, radius);
}

void ParticleSystem::setupForces() {
	tree = new Tree();
	tree->setup(particles);
	int n = particles.size();
	for(int i = 0; i < n; i++)
		particles[i].resetForce();
}

void ParticleSystem::addRepulsionForce(const Particle& particle, float radius, float scale) {
	addRepulsionForce(particle.x, particle.y, radius, scale);
}

void ParticleSystem::addRepulsionForce(float x, float y, float radius, float scale) {
	addForce(x, y, radius, scale);
}

void ParticleSystem::addAttractionForce(const Particle& particle, float radius, float scale) {
	addAttractionForce(particle.x, particle.y, radius, scale);
}

void ParticleSystem::addAttractionForce(float x, float y, float radius, float scale) {
	addForce(x, y, radius, -scale);
}

void ParticleSystem::addForce(const Particle& particle, float radius, float scale) {
	addForce(particle.x, particle.y, radius, -scale);
}

void ParticleSystem::addForce(float x, float y, float radius, float scale) {
	tree->addForce(x, y, radius, scale);

	/*
	// this is another technique that uses the getNeighbors() function
	// for finding nearby particles, then processing them. it's more flexible
	// but not as fast as writing addForce() in Tree itself.
	vector<Particle*> neighbors = getNeighbors(x, y, radius);
	int n = neighbors.size();
	float xd, yd, length, effect;
	for(int i = 0; i < n; i++) {
		Particle& cur = *neighbors[i];
		xd = cur.x - x;
		yd = cur.y - y;
		if(xd != 0 && yd != 0) {
			length = sqrtf(xd * xd + yd * yd);
			xd /= length;
			yd /= length;
			effect = 1 - (length / radius);
			effect *= scale;
			cur.xf += effect * xd;
			cur.yf += effect * yd;
		}
	}
	*/
}

void ParticleSystem::update() {
	int n = particles.size();
	for(int i = 0; i < n; i++)
		particles[i].updatePosition(timeStep);
	if(tree != NULL) {
		delete tree;
		tree = NULL;
	}
}

void ParticleSystem::draw() {
	int n = particles.size();
	//glEnable(GL_POINT_SIZE);
	//glPointSize(2);
	glBegin(GL_POINTS);
	for(int i = 0; i < n; i++)
		particles[i].draw();
	glEnd();
	//glDisable(GL_POINT_SIZE);
}
