import { Error, Ok } from "./gleam.mjs";
import { ElementNotFound } from "./glissome.mjs";

export function getElementTextById(id) {
  const element = document.getElementById(id);
  if (!element) {
    throw new Error(new ElementNotFound(id));
  }
  return new Ok(element.innerText);
}

export function pushEvent(hook, evt, payload, onReply) {
  hook.pushEvent?.(evt, payload, onReply);
  return new Ok(undefined);
}

export function pushEventTo(hook, querySelector, evt, payload, onReply) {
  hook.pushEventTo?.(querySelector, evt, payload, onReply);
  return new Ok(undefined);
}

export function handleEvent(hook, evt, onReply) {
  hook.handleEvent?.(evt, onReply);
  return new Ok(undefined);
}
