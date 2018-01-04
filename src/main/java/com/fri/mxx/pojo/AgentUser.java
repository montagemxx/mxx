package com.fri.mxx.pojo;

import java.util.List;
import java.util.Set;

public class AgentUser extends User{
	private String companyName;
	private Set<String> areas;
	private String firstName;
	private String lastName;
	private String tel;
	private String weChat;
	private String socialNo;
	private boolean searchable;
	private List<Comment> comments;
	
	
	public String getCompanyName() {
		return companyName;
	}
	public void setCompanyName(String companyName) {
		this.companyName = companyName;
	}

	public String getFirstName() {
		return firstName;
	}
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	public String getLastName() {
		return lastName;
	}
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	public String getTel() {
		return tel;
	}
	public void setTel(String tel) {
		this.tel = tel;
	}
	public String getWeChat() {
		return weChat;
	}
	public void setWeChat(String weChat) {
		this.weChat = weChat;
	}
	
	public boolean isSearchable() {
		return searchable;
	}
	public void setSearchable(boolean searchable) {
		this.searchable = searchable;
	}
	public Set<String> getAreas() {
		return areas;
	}
	public void setAreas(Set<String> areas) {
		this.areas = areas;
	}
	public String getSocialNo() {
		return socialNo;
	}
	public void setSocialNo(String socialNo) {
		this.socialNo = socialNo;
	}
	
}
