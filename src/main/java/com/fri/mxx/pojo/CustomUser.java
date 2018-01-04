package com.fri.mxx.pojo;

import java.util.List;

public class CustomUser extends User{
	private List<String> potentialAgents;

	public List<String> getPotentialAgents() {
		return potentialAgents;
	}

	public void setPotentialAgents(List<String> potentialAgents) {
		this.potentialAgents = potentialAgents;
	}
	
	
}
