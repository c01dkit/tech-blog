# Autogen智能体设计

## 安装

```shell
pip install -U "autogen-agentchat" "autogen-ext[openai,azure]"
```

## 官方文档

* [AgentChat](https://microsoft.github.io/autogen/stable//user-guide/agentchat-user-guide/index.html)是高层次的API，基于autogen-core进行封装，适合作为思路验证的起点
* [Autogen-Core](https://microsoft.github.io/autogen/stable//user-guide/core-user-guide/index.html)提供了底层的一些管理接口，允许开发者自行控制智能体交互方式、上下文管理等等，适合深度开发

## 入门例子

```python
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.ui import Console
from autogen_ext.models.openai import OpenAIChatCompletionClient

# Define a model client. You can use other model client that implements
# the `ChatCompletionClient` interface.
model_client = OpenAIChatCompletionClient(
    model="gpt-4o",
    # api_key="YOUR_API_KEY",
)


# Define a simple function tool that the agent can use.
# For this example, we use a fake weather tool for demonstration purposes.
async def get_weather(city: str) -> str:
    """Get the weather for a given city."""
    return f"The weather in {city} is 73 degrees and Sunny."


# Define an AssistantAgent with the model, tool, system message, and reflection enabled.
# The system message instructs the agent via natural language.
agent = AssistantAgent(
    name="weather_agent",
    model_client=model_client,
    tools=[get_weather],
    system_message="You are a helpful assistant.",
    reflect_on_tool_use=True,
    model_client_stream=True,  # Enable streaming tokens from the model client.
)


# Run the agent and stream the messages to the console.
async def main() -> None:
    await Console(agent.run_stream(task="What is the weather in New York?"))
    # Close the connection to the model client.
    await model_client.close()


# NOTE: if running this inside a Python script you'll need to use asyncio.run(main()).
await main()
```

## 一些实现细节

要求模型首先给出结论，并且不要只分两种情况讨论。

**function tools的输入输出说明，是写在Function类的description参数里还是写在system prompt里？**

在function的description里写明函数作用后，好像不用在system prompt里再重复一遍每个函数的输入输出说明了。

**如果function tools返回的并不是最终结果，而是prompt，如何让agent继续分析？**

考虑设计子智能体？在description里写明用法应该也是可以的？

**function tools的参数、返回值的类型能否是自定义的类？大模型能否准确填充内容？**

使用from autogen_core.tools import FunctionTool的FunctionTool来定义工具库，使用pydantic的BaseModel来定义类型，autogen可以自动将这些注册的函数解析为工具集，能够构造复杂的自定义类并准确填充内容，不需要在system prompt中详细说明。在对函数命名和参数命名时要起有意义的名字，帮助模型进行理解。定义FunctionTool对象时，description参数也很重要。

**如何划分function tools和agent？**

**如何做好function tools之间的信息传递？**

**如何做好agent之间的信息传递？**

默认情况下，即使用Autogen自带的RoundRobinGroupChat等方法构建team时，agent之间是共享上下文的。