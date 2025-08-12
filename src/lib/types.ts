import type { CollectionEntry } from "astro:content";

export type PostFrontmatter = CollectionEntry<"blog">["data"] & {
  url: string;
}; 

export type ProjectFrontmatter = CollectionEntry<"projects">["data"] & {
  url: string;
}