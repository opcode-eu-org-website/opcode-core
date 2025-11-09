function create_tabs() {
	for (const demoCodeDiv of document.querySelectorAll(".demo_codes")) {
		const tabElements = demoCodeDiv.querySelectorAll(":scope > pre, :scope > .demo_tab");
		
		const tabs = document.createElement("div");
		tabs.className = "demo_codes_tabs";
		
		tabElements.forEach((pre, i) => {
			const button = document.createElement("button");
			button.textContent = pre.getAttribute("data-title") || "???";
			button.className = "demo_codes_tab_button";
			if (i === 0) {
				button.classList.add("active");
				pre.style.display = "block";
			} else {
				pre.style.display = "none";
			}
			
			button.addEventListener("click", () => {
				demoCodeDiv.querySelectorAll(".demo_codes_tab_button").forEach(btn => btn.classList.remove("active"));
				tabElements.forEach(p => p.style.display = "none");
				
				button.classList.add("active");
				pre.style.display = "block";
			});
			
			tabs.appendChild(button);
		});
		
		demoCodeDiv.insertBefore(tabs, tabElements[0]);
	}
}

addEventListener("DOMContentLoaded", create_tabs);
