// Preprint.swift
import Foundation

struct Preprint: Equatable {
    let id: String
    let title: String
    let abstract: String
    let authors: [String]
    let link: String
    let publishedDate: Date
    let fact: String
}
