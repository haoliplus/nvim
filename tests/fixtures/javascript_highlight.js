function yamlValue(value) {
  if (typeof value === "string") {
    return `"${value
      .replace(/\\/g, "\\\\")
      .replace(/"/g, '\\"')}"`;
  }

  if (typeof value === "boolean") {
    return value ? "true" : "false";
  }

  if (Array.isArray(value)) {
    return `[${value.map(yamlValue).join(", ")}]`;
  }

  return String(value);
}

const lines = ["proxies:"];

function addField(indent, key, value, options = {}) {
  const { keepEmpty = false } = options;
  if (value === undefined || value === null) {
    return;
  }
}
