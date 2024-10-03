//
//  DEBUGGING CODE!
//

import Foundation
import SWXMLHash
import OpenAI

class ArxivServiceStatic {
    func fetchLatestPreprint() async throws -> Preprint? {
        guard let sampleData = getRandomSampleData() else { return nil }
        guard let data = sampleData.data(using: .utf8) else { return nil }
        let preprints = try await parseArxivData(data)
        return preprints.first
    }
    
    func generateFact(from summary: String) async throws -> String {
        let apiKey = APIKeyManager.getAPIKey()
        let openAI = OpenAI(apiToken: apiKey)
        let prompt = """
        Generate one factual sentance to summarize the following text. Make it as short and consise as possible! ONLY RETURN THE GENERATED SENTANCE!

        \(summary)
        """

        guard let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: prompt) else {
            throw NSError(domain: "ArxivServiceStatic", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user message."])
        }

        let chatQuery = ChatQuery(
            messages: [userMessage],
            model: .gpt4_o_mini,
            maxTokens: 250,
            temperature: 0.5
        )

        let result = try await openAI.chats(query: chatQuery)
        return result.choices.first?.message.content?.string ?? "No fact generated"
    }

    private func getRandomSampleData() -> String? {
        if sampleDataOptions.isEmpty { return nil }
        let randomIndex = Int.random(in: 0..<sampleDataOptions.count)
        return sampleDataOptions[randomIndex]
    }

    private func parseArxivData(_ data: Data) async throws -> [Preprint] {
        let xml = SWXMLHash.XMLHash.parse(data)
        var preprints: [Preprint] = []
        
        for entry in xml["feed"]["entry"].all {
            let id = entry["id"].element?.text ?? ""
            
            var title = entry["title"].element?.text ?? "No Title"
            title = title.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var summary = entry["summary"].element?.text ?? "No Summary"
            summary = summary.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let authors = entry["author"].all.compactMap { $0["name"].element?.text }
            let link = entry["id"].element?.text ?? ""
            let publishedString = entry["published"].element?.text ?? ""
            let publishedDate = ISO8601DateFormatter().date(from: publishedString) ?? Date()
            
            let fact = try await generateFact(from: summary)
            
            let preprint = Preprint(
                id: id,
                title: title,
                abstract: summary,
                authors: authors,
                link: link,
                publishedDate: publishedDate,
                fact: fact
            )
            
            preprints.append(preprint)
        }
        
        return preprints
    }

    // Sample data options
    private let sampleDataOptions = [
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <link href="http://arxiv.org/api/query?search_query%3Dall%26id_list%3D%26start%3D0%26max_results%3D1" rel="self" type="application/atom+xml"/>
          <title type="html">ArXiv Query: search_query=all&amp;id_list=&amp;start=0&amp;max_results=1</title>
          <id>http://arxiv.org/api/qNUQqYTSBqOn9wk3n+Jqa7/eio4</id>
          <updated>2024-10-01T00:00:00-04:00</updated>
          <opensearch:totalResults xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">369639</opensearch:totalResults>
          <opensearch:startIndex xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">0</opensearch:startIndex>
          <opensearch:itemsPerPage xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">1</opensearch:itemsPerPage>
          <entry>
            <id>http://arxiv.org/abs/2409.20559v1</id>
            <updated>2024-09-30T17:58:03Z</updated>
            <published>2024-09-30T17:58:03Z</published>
            <title>Supervised Multi-Modal Fission Learning</title>
            <summary>  Learning from multimodal datasets can leverage complementary information and
        improve performance in prediction tasks. A commonly used strategy to account
        for feature correlations in high-dimensional datasets is the latent variable
        approach. Several latent variable methods have been proposed for multimodal
        datasets. However, these methods either focus on extracting the shared
        component across all modalities or on extracting both a shared component and
        individual components specific to each modality. To address this gap, we
        propose a Multi-Modal Fission Learning (MMFL) model that simultaneously
        identifies globally joint, partially joint, and individual components
        underlying the features of multimodal datasets. Unlike existing latent variable
        methods, MMFL uses supervision from the response variable to identify
        predictive latent components and has a natural extension for incorporating
        incomplete multimodal data. Through simulation studies, we demonstrate that
        MMFL outperforms various existing multimodal algorithms in both complete and
        incomplete modality settings. We applied MMFL to a real-world case study for
        early prediction of Alzheimers Disease using multimodal neuroimaging and
        genomics data from the Alzheimers Disease Neuroimaging Initiative (ADNI)
        dataset. MMFL provided more accurate predictions and better insights into
        within- and across-modality correlations compared to existing methods.
        </summary>
            <author>
              <name>Lingchao Mao</name>
            </author>
            <author>
              <name>Qi wang</name>
            </author>
            <author>
              <name>Yi Su</name>
            </author>
            <author>
              <name>Fleming Lure</name>
            </author>
            <author>
              <name>Jing Li</name>
            </author>
            <link href="http://arxiv.org/abs/2409.20559v1" rel="alternate" type="text/html"/>
            <link title="pdf" href="http://arxiv.org/pdf/2409.20559v1" rel="related" type="application/pdf"/>
            <arxiv:primary_category xmlns:arxiv="http://arxiv.org/schemas/atom" term="cs.LG" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.LG" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.CV" scheme="http://arxiv.org/schemas/atom"/>
          </entry>
        </feed>
        """
        ,
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <link href="http://arxiv.org/api/query?search_query%3Dall%26id_list%3D%26start%3D4%26max_results%3D1" rel="self" type="application/atom+xml"/>
          <title type="html">ArXiv Query: search_query=all&amp;id_list=&amp;start=4&amp;max_results=1</title>
          <id>http://arxiv.org/api/feKZr2sJOyRJ+bxHmK2ClDU1pbU</id>
          <updated>2024-10-01T00:00:00-04:00</updated>
          <opensearch:totalResults xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">369639</opensearch:totalResults>
          <opensearch:startIndex xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">4</opensearch:startIndex>
          <opensearch:itemsPerPage xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">1</opensearch:itemsPerPage>
          <entry>
            <id>http://arxiv.org/abs/1612.01842v2</id>
            <updated>2016-12-07T06:10:53Z</updated>
            <published>2016-12-06T15:01:47Z</published>
            <title>An Improved One-to-All Broadcasting in Higher Dimensional
          Eisenstein-Jacobi Networks</title>
            <summary>  Recently, a higher dimensional Eisenstein-Jacobi networks, has been proposed
        in [22], which is shown that they have better average distance with more number
        of nodes than a single dimensional EJ networks. Some communication algorithms
        such as one-to-all and all-to-all communications are well known and used in
        interconnection networks. In one-to-all communication, a source node sends a
        message to every other node in the network. Whereas, in all-to-all
        communication, every node is considered as a source node and sends its message
        to every other node in the network. In this paper, an improved one-to-all
        communication algorithm in higher dimensional EJ networks is presented. The
        paper shows that the proposed algorithm achieves a lower average number of
        steps to receiving the broadcasted message. In addition, since the links are
        assumed to be half-duplex, the all-to-all broadcasting algorithm is divided
        into three phases. The simulation results are discussed and showed that the
        improved one-to-all algorithm achieves better traffic performance than the
        well-known one-to-all algorithm and has 2.7% less total number of senders
        </summary>
            <author>
              <name>Zaid Hussain</name>
            </author>
            <link href="http://arxiv.org/abs/1612.01842v2" rel="alternate" type="text/html"/>
            <link title="pdf" href="http://arxiv.org/pdf/1612.01842v2" rel="related" type="application/pdf"/>
            <arxiv:primary_category xmlns:arxiv="http://arxiv.org/schemas/atom" term="cs.DC" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.DC" scheme="http://arxiv.org/schemas/atom"/>
          </entry>
        </feed>
        """
        ,
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <link href="http://arxiv.org/api/query?search_query%3Dall%26id_list%3D%26start%3D5%26max_results%3D1" rel="self" type="application/atom+xml"/>
          <title type="html">ArXiv Query: search_query=all&amp;id_list=&amp;start=5&amp;max_results=1</title>
          <id>http://arxiv.org/api/eoifxzDERKE8NX/7JyT6vJxNigE</id>
          <updated>2024-10-01T00:00:00-04:00</updated>
          <opensearch:totalResults xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">369639</opensearch:totalResults>
          <opensearch:startIndex xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">5</opensearch:startIndex>
          <opensearch:itemsPerPage xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">1</opensearch:itemsPerPage>
          <entry>
            <id>http://arxiv.org/abs/2309.13541v2</id>
            <updated>2024-04-25T20:40:57Z</updated>
            <published>2023-09-24T03:56:35Z</published>
            <title>Efficient All-to-All Collective Communication Schedules for
          Direct-Connect Topologies</title>
            <summary>  The all-to-all collective communications primitive is widely used in machine
        learning (ML) and high performance computing (HPC) workloads, and optimizing
        its performance is of interest to both ML and HPC communities. All-to-all is a
        particularly challenging workload that can severely strain the underlying
        interconnect bandwidth at scale. This paper takes a holistic approach to
        optimize the performance of all-to-all collective communications on
        supercomputer-scale direct-connect interconnects. We address several
        algorithmic and practical challenges in developing efficient and
        bandwidth-optimal all-to-all schedules for any topology and lowering the
        schedules to various runtimes and interconnect technologies. We also propose a
        novel topology that delivers near-optimal all-to-all performance.
        </summary>
            <author>
              <name>Prithwish Basu</name>
            </author>
            <author>
              <name>Liangyu Zhao</name>
            </author>
            <author>
              <name>Jason Fantl</name>
            </author>
            <author>
              <name>Siddharth Pal</name>
            </author>
            <author>
              <name>Arvind Krishnamurthy</name>
            </author>
            <author>
              <name>Joud Khoury</name>
            </author>
            <arxiv:comment xmlns:arxiv="http://arxiv.org/schemas/atom">HPDC '24</arxiv:comment>
            <link href="http://arxiv.org/abs/2309.13541v2" rel="alternate" type="text/html"/>
            <link title="pdf" href="http://arxiv.org/pdf/2309.13541v2" rel="related" type="application/pdf"/>
            <arxiv:primary_category xmlns:arxiv="http://arxiv.org/schemas/atom" term="cs.DC" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.DC" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.NI" scheme="http://arxiv.org/schemas/atom"/>
          </entry>
        </feed>
        """
        ,
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <link href="http://arxiv.org/api/query?search_query%3Dall%26id_list%3D%26start%3D6%26max_results%3D1" rel="self" type="application/atom+xml"/>
          <title type="html">ArXiv Query: search_query=all&amp;id_list=&amp;start=6&amp;max_results=1</title>
          <id>http://arxiv.org/api/Y1F6uH5DBeVrgxK1MJGavYJpaOw</id>
          <updated>2024-10-01T00:00:00-04:00</updated>
          <opensearch:totalResults xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">369639</opensearch:totalResults>
          <opensearch:startIndex xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">6</opensearch:startIndex>
          <opensearch:itemsPerPage xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">1</opensearch:itemsPerPage>
          <entry>
            <id>http://arxiv.org/abs/2401.11741v1</id>
            <updated>2024-01-22T07:49:56Z</updated>
            <published>2024-01-22T07:49:56Z</published>
            <title>On partial endomorphisms of a star graph</title>
            <summary>  In this paper we consider the monoids of all partial endomorphisms, of all
        partial weak endomorphisms, of all injective partial endomorphisms, of all
        partial strong endomorphisms and of all partial strong weak endomorphisms of a
        star graph with a finite number of vertices. Our main objective is to determine
        their ranks. We also describe their Green's relations, calculate their
        cardinalities and study their regularity.
        </summary>
            <author>
              <name>Ilinka Dimitrova</name>
            </author>
            <author>
              <name>Vítor H. Fernandes</name>
            </author>
            <author>
              <name>Jörg Koppitz</name>
            </author>
            <link href="http://arxiv.org/abs/2401.11741v1" rel="alternate" type="text/html"/>
            <link title="pdf" href="http://arxiv.org/pdf/2401.11741v1" rel="related" type="application/pdf"/>
            <arxiv:primary_category xmlns:arxiv="http://arxiv.org/schemas/atom" term="math.RA" scheme="http://arxiv.org/schemas/atom"/>
            <category term="math.RA" scheme="http://arxiv.org/schemas/atom"/>
            <category term="20M20, 20M10, 05C12, 05C25" scheme="http://arxiv.org/schemas/atom"/>
          </entry>
        </feed>
        """
        ,
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <link href="http://arxiv.org/api/query?search_query%3Dall%26id_list%3D%26start%3D8%26max_results%3D1" rel="self" type="application/atom+xml"/>
          <title type="html">ArXiv Query: search_query=all&amp;id_list=&amp;start=8&amp;max_results=1</title>
          <id>http://arxiv.org/api/vkArirtuvgOy/2wR8buV8NC00Mk</id>
          <updated>2024-10-01T00:00:00-04:00</updated>
          <opensearch:totalResults xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">369639</opensearch:totalResults>
          <opensearch:startIndex xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">8</opensearch:startIndex>
          <opensearch:itemsPerPage xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">1</opensearch:itemsPerPage>
          <entry>
            <id>http://arxiv.org/abs/0705.3599v1</id>
            <updated>2007-05-24T15:45:39Z</updated>
            <published>2007-05-24T15:45:39Z</published>
            <title>Integer symmetric matrices having all their eigenvalues in the interval
          [-2,2]</title>
            <summary>  We completely describe all integer symmetric matrices that have all their
        eigenvalues in the interval [-2,2]. Along the way we classify all signed
        graphs, and then all charged signed graphs, having all their eigenvalues in
        this same interval. We then classify subsets of the above for which the integer
        symmetric matrices, signed graphs and charged signed graphs have all their
        eigenvalues in the open interval (-2,2).
        </summary>
            <author>
              <name>James McKee</name>
            </author>
            <author>
              <name>Chris Smyth</name>
            </author>
            <arxiv:comment xmlns:arxiv="http://arxiv.org/schemas/atom">33 pages, 18 figures</arxiv:comment>
            <link href="http://arxiv.org/abs/0705.3599v1" rel="alternate" type="text/html"/>
            <link title="pdf" href="http://arxiv.org/pdf/0705.3599v1" rel="related" type="application/pdf"/>
            <arxiv:primary_category xmlns:arxiv="http://arxiv.org/schemas/atom" term="math.CO" scheme="http://arxiv.org/schemas/atom"/>
            <category term="math.CO" scheme="http://arxiv.org/schemas/atom"/>
            <category term="math.NT" scheme="http://arxiv.org/schemas/atom"/>
            <category term="05C50;11C20;05C22;15A36" scheme="http://arxiv.org/schemas/atom"/>
          </entry>
        </feed>
        """
        ,
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <link href="http://arxiv.org/api/query?search_query%3Dall%26id_list%3D%26start%3D0%26max_results%3D1" rel="self" type="application/atom+xml"/>
          <title type="html">ArXiv Query: search_query=all&amp;id_list=&amp;start=0&amp;max_results=1</title>
          <id>http://arxiv.org/api/qNUQqYTSBqOn9wk3n+Jqa7/eio4</id>
          <updated>2024-10-03T00:00:00-04:00</updated>
          <opensearch:totalResults xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">369896</opensearch:totalResults>
          <opensearch:startIndex xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">0</opensearch:startIndex>
          <opensearch:itemsPerPage xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">1</opensearch:itemsPerPage>
          <entry>
            <id>http://arxiv.org/abs/2410.01802v1</id>
            <updated>2024-10-02T17:57:38Z</updated>
            <published>2024-10-02T17:57:38Z</published>
            <title>PROXI: Challenging the GNNs for Link Prediction</title>
            <summary>  Over the past decade, Graph Neural Networks (GNNs) have transformed graph
        representation learning. In the widely adopted message-passing GNN framework,
        nodes refine their representations by aggregating information from neighboring
        nodes iteratively. While GNNs excel in various domains, recent theoretical
        studies have raised concerns about their capabilities. GNNs aim to address
        various graph-related tasks by utilizing such node representations, however,
        this one-size-fits-all approach proves suboptimal for diverse tasks.
          Motivated by these observations, we conduct empirical tests to compare the
        performance of current GNN models with more conventional and direct methods in
        link prediction tasks. Introducing our model, PROXI, which leverages proximity
        information of node pairs in both graph and attribute spaces, we find that
        standard machine learning (ML) models perform competitively, even outperforming
        cutting-edge GNN models when applied to these proximity metrics derived from
        node neighborhoods and attributes. This holds true across both homophilic and
        heterophilic networks, as well as small and large benchmark datasets, including
        those from the Open Graph Benchmark (OGB). Moreover, we show that augmenting
        traditional GNNs with PROXI significantly boosts their link prediction
        performance. Our empirical findings corroborate the previously mentioned
        theoretical observations and imply that there exists ample room for enhancement
        in current GNN models to reach their potential.
        </summary>
            <author>
              <name>Astrit Tola</name>
            </author>
            <author>
              <name>Jack Myrick</name>
            </author>
            <author>
              <name>Baris Coskunuzer</name>
            </author>
            <link href="http://arxiv.org/abs/2410.01802v1" rel="alternate" type="text/html"/>
            <link title="pdf" href="http://arxiv.org/pdf/2410.01802v1" rel="related" type="application/pdf"/>
            <arxiv:primary_category xmlns:arxiv="http://arxiv.org/schemas/atom" term="cs.LG" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.LG" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.CG" scheme="http://arxiv.org/schemas/atom"/>
          </entry>
        </feed>
        """
        ,
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <link href="http://arxiv.org/api/query?search_query%3Dall%26id_list%3D%26start%3D2%26max_results%3D1" rel="self" type="application/atom+xml"/>
          <title type="html">ArXiv Query: search_query=all&amp;id_list=&amp;start=2&amp;max_results=1</title>
          <id>http://arxiv.org/api/YtXMZe3fucOLKoUfMrnDZUPygwM</id>
          <updated>2024-10-03T00:00:00-04:00</updated>
          <opensearch:totalResults xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">369896</opensearch:totalResults>
          <opensearch:startIndex xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">2</opensearch:startIndex>
          <opensearch:itemsPerPage xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">1</opensearch:itemsPerPage>
          <entry>
            <id>http://arxiv.org/abs/2410.01798v1</id>
            <updated>2024-10-02T17:55:46Z</updated>
            <published>2024-10-02T17:55:46Z</published>
            <title>Windowed MAPF with Completeness Guarantees</title>
            <summary>  Traditional multi-agent path finding (MAPF) methods try to compute entire
        start-goal paths which are collision free. However, computing an entire path
        can take too long for MAPF systems where agents need to replan fast. Methods
        that address this typically employ a "windowed" approach and only try to find
        collision free paths for a small windowed timestep horizon. This adaptation
        comes at the cost of incompleteness; all current windowed approaches can become
        stuck in deadlock or livelock. Our main contribution is to introduce our
        framework, WinC-MAPF, for Windowed MAPF that enables completeness. Our
        framework uses heuristic update insights from single-agent real-time heuristic
        search algorithms as well as agent independence ideas from MAPF algorithms. We
        also develop Single-Step CBS (SS-CBS), an instantiation of this framework using
        a novel modification to CBS. We show how SS-CBS, which only plans a single step
        and updates heuristics, can effectively solve tough scenarios where existing
        windowed approaches fail.
        </summary>
            <author>
              <name>Rishi Veerapaneni</name>
            </author>
            <author>
              <name>Muhammad Suhail Saleem</name>
            </author>
            <author>
              <name>Jiaoyang Li</name>
            </author>
            <author>
              <name>Maxim Likhachev</name>
            </author>
            <link href="http://arxiv.org/abs/2410.01798v1" rel="alternate" type="text/html"/>
            <link title="pdf" href="http://arxiv.org/pdf/2410.01798v1" rel="related" type="application/pdf"/>
            <arxiv:primary_category xmlns:arxiv="http://arxiv.org/schemas/atom" term="cs.MA" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.MA" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.AI" scheme="http://arxiv.org/schemas/atom"/>
            <category term="cs.RO" scheme="http://arxiv.org/schemas/atom"/>
          </entry>
        </feed>
        """
    ]
}
