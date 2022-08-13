const togglerBtn = document.getElementById("navbarSupportedContentToggler");
const navbarContent = document.getElementById("navbarSupportedContent");

navbarContent.addEventListener("show.bs.collapse", () => {
  console.log("opening navbar content");
  togglerBtn.classList.toggle("is-active");
});

navbarContent.addEventListener("hide.bs.collapse", () => {
  console.log("closing navbar content");
  togglerBtn.classList.toggle("is-active");
});
