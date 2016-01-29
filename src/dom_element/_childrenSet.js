class ChildrenSet {

  constructor(element) {
    this.element = element;
  }

  clear() {
    let el;
    while ((el = this.element.lastChild)) this.element.removeChild(el);
    return this;
  }

  add(element) {
    if (!this.has(element)) {
      this.element.appendChild(element);
    }
    return this;
  }

  remove(element) {
    if (this.has(element)) {
      return this.element.removeChild(element);
    }
  }

  move(element, afterElement) {
    if (
      !this.has(element) || !(afterElement != null && this.has(afterElement))
        || element === afterElement
    ) {
      return this;
    }

    if (element.previousSibling === afterElement) return this;

    this.remove(element);
    let beforeElement;
    if (afterElement == null) {
      beforeElement = this.element.firstChild;
    } else {
      beforeElement = afterElement.nextSibling;
    }

    // If beforeElement is null,
    // element is inserted at the end of the list of child nodes.
    this.element.insertBefore(element, beforeElement);

    return this;
  }

  has(element) {
    return element.parentNode === this.element;
  }

  *[Symbol.iterator]() {
    // TODO: Use real DOM iterator
    for (const element of Array.from(this.element.childNodes)) {
      yield [null, element];
    }
  }

  getSize() {
    return this.element.childNodes.length;
  }


  visit(element) {
    if (this.has(element)) {
      element.visited = true;
    }
    return this;
  }

  *iterateAndClearUnvisitedKeys() {
    for (const element of Array.from(this.element.childNodes)) {
      if (!element.visited) yield element;
      element.visited = false;
    }
  }
}

export function createChildrenSet(element) {
  return new ChildrenSet(element);
}
