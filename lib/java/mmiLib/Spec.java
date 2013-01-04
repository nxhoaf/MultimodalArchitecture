package mmiLib;

public class Spec {
	// Non-normalized attributes
	private String api; 
	private String type; 
	private String metadata;
	private String deliveryMode;
	private Boolean isDelivered;
	private String method; 

	// normalized
	private String requestId; 
	private String source;
	private String target; 
	private String data; 
	private String context; 
	private Boolean confidential; 
	private String status; 
	private String statusInfo; 
	private String name; 

	// optional 
	private String content; 
	private String contentUrl; 
	private Boolean immediate;
	private Boolean requestAutomaticUpdate; // For request
	private Boolean automaticUpdate; // For response
	private String token;
	
	public Spec() {
		// Non-normalized attributes
		this.api = ""; 
		this.type = ""; 
		this.metadata = "";
		this.deliveryMode = "";
		this.isDelivered = true;
		this.method = ""; 

		// normalized
		this.requestId = ""; 
		this.source = "";
		this.target = ""; 
		this.data = ""; 
		this.context = ""; 
		this.confidential = true; 
		this.status = ""; 
		this.statusInfo = ""; 
		this.name = ""; 

		// optional 
		this.content = ""; 
		this.contentUrl = ""; 
		this.immediate = true;
		this.requestAutomaticUpdate = false; // For request
		this.automaticUpdate = false; // For response
		this.token = "";
	}

	public String getApi() {
		return api;
	}

	public void setApi(String api) {
		this.api = api;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getMetadata() {
		return metadata;
	}

	public void setMetadata(String metadata) {
		this.metadata = metadata;
	}

	public String getDeliveryMode() {
		return deliveryMode;
	}

	public void setDeliveryMode(String deliveryMode) {
		this.deliveryMode = deliveryMode;
	}

	public Boolean getIsDelivered() {
		return isDelivered;
	}

	public void setIsDelivered(Boolean isDelivered) {
		this.isDelivered = isDelivered;
	}

	public String getMethod() {
		return method;
	}

	public void setMethod(String method) {
		this.method = method;
	}

	public String getRequestId() {
		return requestId;
	}

	public void setRequestId(String requestId) {
		this.requestId = requestId;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getTarget() {
		return target;
	}

	public void setTarget(String target) {
		this.target = target;
	}

	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}

	public String getContext() {
		return context;
	}

	public void setContext(String context) {
		this.context = context;
	}

	public Boolean getConfidential() {
		return confidential;
	}

	public void setConfidential(Boolean confidential) {
		this.confidential = confidential;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getStatusInfo() {
		return statusInfo;
	}

	public void setStatusInfo(String statusInfo) {
		this.statusInfo = statusInfo;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public String getContentUrl() {
		return contentUrl;
	}

	public void setContentUrl(String contentUrl) {
		this.contentUrl = contentUrl;
	}

	public Boolean getImmediate() {
		return immediate;
	}

	public void setImmediate(Boolean immediate) {
		this.immediate = immediate;
	}

	public Boolean getRequestAutomaticUpdate() {
		return requestAutomaticUpdate;
	}

	public void setRequestAutomaticUpdate(Boolean requestAutomaticUpdate) {
		this.requestAutomaticUpdate = requestAutomaticUpdate;
	}

	public Boolean getAutomaticUpdate() {
		return automaticUpdate;
	}

	public void setAutomaticUpdate(Boolean automaticUpdate) {
		this.automaticUpdate = automaticUpdate;
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}
	
	
}
