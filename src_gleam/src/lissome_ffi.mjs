import { Error, Ok } from "./gleam.mjs";
import { ElementNotFound } from "./lissome.mjs";

export function getElementTextById(id) {
  const element = document.getElementById(id);
  if (!element) {
    throw new Error(new ElementNotFound(id));
  }
  return new Ok(element.innerText);
}
